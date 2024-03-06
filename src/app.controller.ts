import { Controller, Get, Param } from '@nestjs/common';
import { AppService } from './app.service';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly httpService: HttpService,
  ) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('repos/:username')
  async getGithubRepos(@Param() params: any): Promise<any> {
    const response = await firstValueFrom(
      this.httpService.get<any[]>(
        `${process.env.GITHUB_API}/users/${params.username}/repos`,
        {
          headers: {
            Accept: 'application/vnd.github.v3+json',
          },
        },
      ),
    );

    return response.data
      .map((repo) => ({
        name: repo.name,
        full_name: repo.full_name,
        description: repo.description,
        created_at: repo.created_at,
        updated_at: repo.updated_at,
        language: repo.language,
        visibility: repo.visibility,
      }))
      .slice(0, 3);
  }
}
